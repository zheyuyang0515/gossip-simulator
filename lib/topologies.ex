defmodule Topologies do
    defp get_coordinator_2D(basic, list) do
        x = :rand.uniform(basic)
        y = :rand.uniform(basic)
        {x, y} = if Enum.member?(list, {x, y}) == true do
            get_coordinator_2D(basic, list)
        else
            {x, y}
        end
        {x, y}
    end
    defp get_random_node(list, nodes) do
        node = Enum.random(nodes)
        node = if Enum.member?(list, node) == true do
            get_random_node(list, nodes)
        else
            node
        end
        node
    end
    def findNeighbor(topology, nodes) do
        len = length(nodes)
        case topology do
            "full" -> Enum.map(nodes, fn node ->
                GenServer.cast(node, {:neighbor, nodes -- List.wrap(node)})
            end)
            "line" -> if length(nodes) == 1 do
                GenServer.cast(Enum.at(nodes, 0), {:neighbor, []})
            else
                Enum.map(0..len - 1, fn i ->
                    node = Enum.at(nodes, i)
                    neighbor = if i - 1 >= 0 && i + 1 < len do
                        [Enum.at(nodes, i - 1), Enum.at(nodes, i + 1)]
                    else
                        if i - 1 < 0 && i + 1 < len do
                            [Enum.at(nodes, i + 1)]
                        else
                            [Enum.at(nodes, i - 1)]
                        end
                    end
                    GenServer.cast(node, {:neighbor, neighbor})
                end)
            end
            "rand2D" -> basic = :math.sqrt(length(nodes)) |> floor
                list = []
                list = Enum.map(0..len - 1, fn _ ->
                    if(length(list) < basic * basic) do
                        {x, y} = get_coordinator_2D(basic, list)
                        list ++ {x, y}
                    end
                end)
                Enum.map(0..len - 1, fn i ->
                    {x, y} = Enum.at(list, i)
                    node = Enum.at(nodes, i)
                    neighbor = []
                    neighbor = Enum.map(0..len - 1, fn j ->
                        {x2, y2} = Enum.at(list, j)
                        node2 = Enum.at(nodes, j)
                        if node2 == node do
                            neighbor
                        else
                            if (:math.pow(x - x2, 2) + :math.pow(y - y2, 2)) |> :math.sqrt |> round < 10 do
                                neighbor ++ List.wrap(node2)
                            else
                                neighbor
                            end
                        end

                    end)
                    neighbor = List.flatten(neighbor)
                    GenServer.cast(node, {:neighbor, neighbor})
                end)
                "3Dtorus" -> noLine = :math.pow(length(nodes) , 1 / 3) |> ceil
                nolayer = noLine * noLine
                totalNode = noLine * noLine * noLine
                #IO.puts(noLine)
                #Enum.map(totalNode..length(nodes) - 1, fn p ->
                    #GenServer.cast(Enum.at(nodes, p), {:neighbor, []})
                #end)
                Enum.map(0..totalNode - 1, fn i ->
                j = Integer.mod(i, nolayer)
                cond do
                   j == 0 ->
                        if i == 0 do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i + (noLine - 1)), Enum.at(nodes, i + noLine), Enum.at(nodes, i + nolayer), Enum.at(nodes, i + noLine * (noLine - 1)), Enum.at(nodes, i + (noLine - 1) * nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if i == (noLine - 1) * nolayer do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i + (noLine - 1)), Enum.at(nodes, i + noLine), Enum.at(nodes, i - nolayer), Enum.at(nodes, i + noLine * (noLine - 1)), Enum.at(nodes, i - (noLine - 1) * nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if i < (noLine - 1) * nolayer && i > 0 do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i + (noLine - 1)), Enum.at(nodes, i + noLine), Enum.at(nodes, i - nolayer), Enum.at(nodes, i + noLine * (noLine - 1)), Enum.at(nodes, i + nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                    j == noLine - 1 ->
                        if i == noLine - 1 do
                            list = [Enum.at(nodes, i - 1), Enum.at(nodes, i + noLine), Enum.at(nodes, i - (noLine - 1)), Enum.at(nodes, i + nolayer), Enum.at(nodes, i + noLine * (noLine - 1)), Enum.at(nodes, i + nolayer * (noLine - 1))]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if i == (noLine - 1) * nolayer + noLine - 1 do
                            list = [Enum.at(nodes, i - 1), Enum.at(nodes, i + noLine), Enum.at(nodes, i - (noLine - 1)), Enum.at(nodes, i - nolayer), Enum.at(nodes, i + noLine * (noLine - 1)), Enum.at(nodes, i - nolayer * (noLine - 1))]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if i < (noLine - 1) * nolayer + noLine - 1 && i > noLine - 1 do
                            list = [Enum.at(nodes, i - 1), Enum.at(nodes, i + noLine), Enum.at(nodes, i - (noLine - 1)), Enum.at(nodes, i - nolayer), Enum.at(nodes, i + noLine * (noLine - 1)), Enum.at(nodes, i + nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                    j == noLine * (noLine - 1) ->
                        if i == noLine * (noLine - 1) do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + (noLine - 1)), Enum.at(nodes, i + nolayer), Enum.at(nodes, i - noLine * (noLine - 1)), Enum.at(nodes, i + nolayer * (noLine - 1))]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if i == (noLine - 1) * nolayer + noLine * (noLine - 1) do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + (noLine - 1)), Enum.at(nodes, i - nolayer), Enum.at(nodes, i - noLine * (noLine - 1)), Enum.at(nodes, i - nolayer * (noLine - 1))]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if i <  (noLine - 1) * nolayer + noLine * (noLine - 1) && i > noLine * (noLine - 1) do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + (noLine - 1)), Enum.at(nodes, i - nolayer), Enum.at(nodes, i - noLine * (noLine - 1)), Enum.at(nodes, i + nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                    j == nolayer - 1 ->
                        if i == nolayer - 1 do
                            list = [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i - (noLine - 1)), Enum.at(nodes, i + nolayer), Enum.at(nodes, i - noLine * (noLine - 1)), Enum.at(nodes, i + nolayer * (noLine - 1))]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if i == totalNode - 1 do
                            list = [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i - (noLine - 1)), Enum.at(nodes, i - nolayer), Enum.at(nodes, i - noLine * (noLine - 1)), Enum.at(nodes, i - nolayer * (noLine - 1))]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if i <  totalNode - 1 && i > nolayer - 1 do
                            list = [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i - (noLine - 1)), Enum.at(nodes, i - nolayer), Enum.at(nodes, i - noLine * (noLine - 1)),Enum.at(nodes, i + nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
    #node 1
                    j > 0 &&  j < noLine - 1 ->
                        if i < noLine - 1 do
                            list = [Enum.at(nodes, i - 1), Enum.at(nodes, i + 1), Enum.at(nodes, i + noLine), Enum.at(nodes, i + nolayer), Enum.at(nodes, i + noLine * (noLine - 1)), Enum.at(nodes, i + nolayer * (noLine - 1))]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if i > (noLine - 1) * nolayer do
                            list = [Enum.at(nodes, i - 1), Enum.at(nodes, i + 1), Enum.at(nodes, i + noLine),  Enum.at(nodes, i - nolayer), Enum.at(nodes, i + noLine * (noLine - 1)), Enum.at(nodes, i - nolayer * (noLine - 1))]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if i < (noLine - 1) * nolayer  && i > noLine - 1 do
                            list = [Enum.at(nodes, i - 1), Enum.at(nodes, i + 1), Enum.at(nodes, i + noLine),  Enum.at(nodes, i - nolayer), Enum.at(nodes, i + noLine * (noLine - 1)), Enum.at(nodes, i + nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
    #node 5
                    j >= 2 * noLine - 1 &&  j <= nolayer - noLine - 1 && Integer.mod(j + 1, noLine) == 0 ->
                        if i >=2 * noLine - 1  &&  i <= nolayer - noLine - 1 do
                            list = [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine), Enum.at(nodes, i + nolayer), Enum.at(nodes, i + noLine * (noLine - 1)), Enum.at(nodes, i -(noLine - 1))]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if  i > nolayer * (noLine - 1) do
                            list = [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine), Enum.at(nodes, i - nolayer), Enum.at(nodes, i - noLine * (noLine - 1)), Enum.at(nodes, i - (noLine - 1))]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                           # IO.inspect({i, list})
                        end
                        if i >= nolayer   &&  i < (noLine - 1) * nolayer do
                            list = [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine),  Enum.at(nodes, i - nolayer), Enum.at(nodes, i - noLine * (noLine - 1)),Enum.at(nodes, i + nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                   #node 3
                    j >= noLine &&  j <= nolayer - noLine - 1 && Integer.mod(j, noLine) == 0 ->
                        if i >= noLine &&  i <= nolayer - noLine - 1 do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine), Enum.at(nodes, i + nolayer), Enum.at(nodes, i + noLine * (noLine - 1)), Enum.at(nodes, i +(noLine - 1))]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if  i >= nolayer * (noLine - 1) do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine), Enum.at(nodes, i - nolayer), Enum.at(nodes, i - noLine * (noLine - 1)), Enum.at(nodes, i + (noLine - 1))]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if i >= nolayer  &&  i < (noLine - 1) * nolayer do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine),  Enum.at(nodes, i - nolayer), Enum.at(nodes, i + (noLine - 1)), Enum.at(nodes, i + nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                    #node 7
                    j > noLine * (noLine - 1) &&  j < (nolayer - 1) ->
                        if i < nolayer  do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine),  Enum.at(nodes, i + nolayer), Enum.at(nodes, i - noLine * (noLine - 1)), Enum.at(nodes, i + (noLine - 1) * nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if  i >= nolayer * (noLine - 1) do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i - nolayer), Enum.at(nodes, i - noLine * (noLine - 1)), Enum.at(nodes, i - (noLine - 1) * nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if i >= nolayer  &&  i < (noLine - 1) * nolayer do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine),  Enum.at(nodes, i - nolayer),  Enum.at(nodes, i + nolayer), Enum.at(nodes, i - (noLine - 1) * noLine)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                    true ->
                    if i < nolayer  do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine),  Enum.at(nodes, i + nolayer), Enum.at(nodes, i + noLine), Enum.at(nodes, i + (noLine - 1) * nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if  i >= nolayer * (noLine - 1) do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i - nolayer), Enum.at(nodes, i + noLine),  Enum.at(nodes, i - (noLine - 1) * nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                        if i >= nolayer  &&  i < (noLine - 1) * nolayer do
                            list = [Enum.at(nodes, i + 1), Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine),  Enum.at(nodes, i + noLine), Enum.at(nodes, i - nolayer),  Enum.at(nodes, i + nolayer)]
                            GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                            #IO.inspect({i, list})
                        end
                end
            end)
            "randhoneycomb" -> size = length(nodes)
            noLine = :math.sqrt(size) |> floor
            line = noLine
            noTotal = noLine * noLine
            rest = size - noTotal
            line = if rest != 0 do
                line + 1
            else
                line
            end
            if Integer.mod(noLine, 2) == 0 do
                Enum.map(0..length(nodes) - 1, fn i ->
                    row = div(i, noLine)
                    col = Integer.mod(i, noLine)
                    list = []
                    list = list ++ if (Integer.mod(row, 2) == 0 && Integer.mod(col, 2) == 0) || (Integer.mod(row, 2) != 0 && Integer.mod(col, 2) != 0) do
                        cond do
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 && i - noLine >= 0 -> [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine)]
                            i < size && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 && i + noLine < size -> [Enum.at(nodes, i - 1), Enum.at(nodes, i + noLine)]
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 -> [Enum.at(nodes, i - 1)]
                            i < size && i - noLine >= 0 -> [Enum.at(nodes, i - noLine)]
                            i < size && i + noLine < size -> [Enum.at(nodes, i + noLine)]
                        end
                    else
                        []
                    end
                    list = list ++ if (Integer.mod(row, 2) == 0 && Integer.mod(col, 2) != 0) || (Integer.mod(row, 2) != 0 && Integer.mod(col, 2) == 0) do
                        cond do
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 && i - noLine >= 0 -> [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine)]
                            i < size && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 && i + noLine < size -> [Enum.at(nodes, i + 1), Enum.at(nodes, i + noLine)]
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 -> [Enum.at(nodes, i + 1)]
                            i < size && i - noLine >= 0 -> [Enum.at(nodes, i - noLine)]
                            i < size && i + noLine < size -> [Enum.at(nodes, i + noLine)]
                        end
                    else
                        []
                    end
                    list = list ++ List.wrap(get_random_node(list, nodes))
                    GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                end)
            else
                Enum.map(0..length(nodes) - 1, fn i ->
                    row = div(i, noLine)
                    col = Integer.mod(i, noLine)
                    list = []
                    list = list ++ if (Integer.mod(row, 2) == 0 && Integer.mod(col, 2) == 0) || (Integer.mod(row, 2) != 0 && Integer.mod(col, 2) != 0) do
                        cond do
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine)  != 0 && i - noLine >= 0 -> [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine)]
                            i < size && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 && i + noLine < size -> [Enum.at(nodes, i - 1), Enum.at(nodes, i + noLine)]
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 -> [Enum.at(nodes, i - 1)]
                            i < size && i - noLine >= 0 -> [Enum.at(nodes, i - noLine)]
                            i < size && i + noLine < size -> [Enum.at(nodes, i + noLine)]
                        end
                    else
                        []
                    end
                    list = list ++ if (Integer.mod(row, 2) == 0 && Integer.mod(col, 2) != 0) || (Integer.mod(row, 2) != 0 && Integer.mod(col, 2) == 0) do
                        cond do
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 && i - noLine >= 0 -> [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine)]
                            i < size && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 && i + noLine < size -> [Enum.at(nodes, i + 1), Enum.at(nodes, i + noLine)]
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 -> [Enum.at(nodes, i + 1)]
                            i < size && i - noLine >= 0 -> [Enum.at(nodes, i - noLine)]
                            i < size && i + noLine < size -> [Enum.at(nodes, i + noLine)]
                        end
                    else
                        []
                    end
                    list = list ++ List.wrap(get_random_node(list, nodes))
                    GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                end)
            end
            "honeycomb" -> size = length(nodes)
            noLine = :math.sqrt(size) |> floor
            line = noLine
            noTotal = noLine * noLine
            rest = size - noTotal
            line = if rest != 0 do
                line + 1
            else
                line
            end
            if Integer.mod(noLine, 2) == 0 do
                Enum.map(0..length(nodes) - 1, fn i ->
                    row = div(i, noLine)
                    col = Integer.mod(i, noLine)
                    list = []
                    list = list ++ if (Integer.mod(row, 2) == 0 && Integer.mod(col, 2) == 0) || (Integer.mod(row, 2) != 0 && Integer.mod(col, 2) != 0) do
                        cond do
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 && i - noLine >= 0 -> [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine)]
                            i < size && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 && i + noLine < size -> [Enum.at(nodes, i - 1), Enum.at(nodes, i + noLine)]
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 -> [Enum.at(nodes, i - 1)]
                            i < size && i - noLine >= 0 -> [Enum.at(nodes, i - noLine)]
                            i < size && i + noLine < size -> [Enum.at(nodes, i + noLine)]
                        end
                    else
                        []
                    end
                    list = list ++ if (Integer.mod(row, 2) == 0 && Integer.mod(col, 2) != 0) || (Integer.mod(row, 2) != 0 && Integer.mod(col, 2) == 0) do
                        cond do
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 && i - noLine >= 0 -> [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine)]
                            i < size && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 && i + noLine < size -> [Enum.at(nodes, i + 1), Enum.at(nodes, i + noLine)]
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 -> [Enum.at(nodes, i + 1)]
                            i < size && i - noLine >= 0 -> [Enum.at(nodes, i - noLine)]
                            i < size && i + noLine < size -> [Enum.at(nodes, i + noLine)]
                        end
                    else
                        []
                    end
                    GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                end)
            else
                Enum.map(0..length(nodes) - 1, fn i ->
                    row = div(i, noLine)
                    col = Integer.mod(i, noLine)
                    list = []
                    list = list ++ if (Integer.mod(row, 2) == 0 && Integer.mod(col, 2) == 0) || (Integer.mod(row, 2) != 0 && Integer.mod(col, 2) != 0) do
                        cond do
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine)  != 0 && i - noLine >= 0 -> [Enum.at(nodes, i - 1), Enum.at(nodes, i - noLine)]
                            i < size && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 && i + noLine < size -> [Enum.at(nodes, i - 1), Enum.at(nodes, i + noLine)]
                            i < size && i - 1 >= 0 && Integer.mod(i, noLine) != 0 -> [Enum.at(nodes, i - 1)]
                            i < size && i - noLine >= 0 -> [Enum.at(nodes, i - noLine)]
                            i < size && i + noLine < size -> [Enum.at(nodes, i + noLine)]
                        end
                    else
                        []
                    end
                    list = list ++ if (Integer.mod(row, 2) == 0 && Integer.mod(col, 2) != 0) || (Integer.mod(row, 2) != 0 && Integer.mod(col, 2) == 0) do
                        cond do
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 && i - noLine >= 0 -> [Enum.at(nodes, i + 1), Enum.at(nodes, i - noLine)]
                            i < size && i - noLine >= 0 && i + noLine < size -> [Enum.at(nodes, i - noLine), Enum.at(nodes, i + noLine)]
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 && i + noLine < size -> [Enum.at(nodes, i + 1), Enum.at(nodes, i + noLine)]
                            i < size && i + 1 < size && Integer.mod(i + 1, noLine) != 0 -> [Enum.at(nodes, i + 1)]
                            i < size && i - noLine >= 0 -> [Enum.at(nodes, i - noLine)]
                            i < size && i + noLine < size -> [Enum.at(nodes, i + noLine)]
                        end
                    else
                        []
                    end
                    GenServer.cast(Enum.at(nodes, i), {:neighbor, list})
                end)
            end
        end
    end
end
